package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.action.Target
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.Recipient
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.ScreenSnapshot
import com.alesle.ai.agent.snapshot.UiNode
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SafetyPolicyTest {
    private class Node(
        override val text: String? = null,
        override val contentDescription: String? = null,
        override val bounds: Bounds,
    ) : UiNode {
        override val className = "android.widget.TextView"
        override val hintText: String? = null
        override val isShowingHintText = false
        override val viewId: String? = null
        override val isVisibleToUser = true
        override val isClickable = true
        override val isLongClickable = false
        override val isEditable = false
        override val isEnabled = true
        override val isFocused = false
        override val isScrollable = false
        override val isCheckable = false
        override val isChecked = false
        override val isPassword = false
        override val children = emptyList<UiNode>()
    }

    private fun screen(
        vararg nodes: UiNode,
        packageName: String = "org.telegram.messenger",
    ) = CapturedScreen(
        ScreenSnapshot("s", packageName, null, "h", "uz", Orientation.PORTRAIT, emptyList(), keyboardVisible = false, truncated = false),
        nodes.toList(),
        Bounds(0, 0, 1000, 2000),
    )

    private fun call(to: Recipient) = DecodedAction.Intent(IntentAction.Call(to))

    private fun tap(target: Target) = DecodedAction.Screen(AgentAction.Tap(target))

    @Test
    fun `a call always asks, a raw number always, and USSD codes are refused`() {
        val contact = SafetyPolicy.check(call(Recipient.ContactName("Onam")), null, "uz") as SafetyVerdict.Confirm
        assertEquals(Confirmation("Qo‘ng‘iroq qilinsinmi?", "Onam", always = false), contact.confirmation)
        val number = SafetyPolicy.check(call(Recipient.Phone("+998 90 123-45-67")), null, "ru") as SafetyVerdict.Confirm
        assertEquals(Confirmation("Позвонить?", "+998 90 123-45-67", always = true), number.confirmation)
        for (bad in listOf("*880*12345*50000#", "#31#", "12", "tel:123", "+1234567890123456789012")) {
            assertEquals(bad, SafetyVerdict.Block("unsafe_number"), SafetyPolicy.check(call(Recipient.Phone(bad)), null, "en"))
        }
        assertTrue(SafetyPolicy.check(call(Recipient.ContactRef("c1")), null, "en") is SafetyVerdict.Confirm)
    }

    @Test
    fun `Alesle never operates itself`() {
        assertEquals(
            SafetyVerdict.Block("own_app"),
            SafetyPolicy.check(DecodedAction.Intent(IntentAction.LaunchApp(packageName = "com.alesle.ai")), null, "en"),
        )
        assertEquals(
            SafetyVerdict.Block("own_app"),
            SafetyPolicy.check(DecodedAction.Intent(IntentAction.LaunchApp(appName = " Alesle ")), null, "en"),
        )
        val own = screen(Node(text = "Ask before sending", bounds = Bounds(0, 0, 1000, 100)), packageName = "com.alesle.ai")
        assertEquals(SafetyVerdict.Block("own_app"), SafetyPolicy.check(tap(Target.Node(0)), own, "en"))
        assertEquals(
            SafetyVerdict.Allow,
            SafetyPolicy.check(DecodedAction.Intent(IntentAction.LaunchApp(packageName = "org.telegram.messenger")), null, "en"),
        )
    }

    @Test
    fun `taps on send, call, pay and delete ask with the button's own words`() {
        val s =
            screen(
                Node(contentDescription = "Send", bounds = Bounds(800, 1800, 1000, 2000)),
                Node(bounds = Bounds(0, 1000, 1000, 1100)),
                Node(text = "To‘lash 63 000 so‘m", bounds = Bounds(10, 1010, 990, 1090)),
                Node(text = "Удалить чат", bounds = Bounds(0, 500, 1000, 600)),
                Node(text = "Hello", bounds = Bounds(0, 0, 1000, 100)),
                Node(text = "Позвонить", bounds = Bounds(0, 200, 1000, 300)),
            )
        val send = SafetyPolicy.check(tap(Target.Node(0)), s, "uz") as SafetyVerdict.Confirm
        assertEquals(Confirmation("Yuborilsinmi?", "Send", always = false), send.confirmation)
        // The label drawn inside the tapped node counts too.
        val pay = SafetyPolicy.check(tap(Target.Node(1)), s, "en") as SafetyVerdict.Confirm
        assertEquals(Confirmation("Pay?", "To‘lash 63 000 so‘m", always = true), pay.confirmation)
        val delete = SafetyPolicy.check(DecodedAction.Screen(AgentAction.LongPress(Target.Node(3))), s, "ru") as SafetyVerdict.Confirm
        assertTrue(delete.confirmation.always)
        assertEquals("Позвонить?", (SafetyPolicy.check(tap(Target.Node(5)), s, "ru") as SafetyVerdict.Confirm).confirmation.title)
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(tap(Target.Node(4)), s, "en"))
        // Vision taps by point land on the smallest node there.
        assertTrue(SafetyPolicy.check(tap(Target.Point(0.9, 0.95)), s, "en") is SafetyVerdict.Confirm)
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(tap(Target.Point(0.5, 0.01)), s, "en"))
    }

    @Test
    fun `other actions and unknown targets pass`() {
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(DecodedAction.Screen(AgentAction.Global(GlobalAction.BACK)), null, "en"))
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(tap(Target.Node(9)), screen(), "en"))
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(tap(Target.Node(0)), null, "en"))
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(DecodedAction.WaitForUser(5_000), null, "en"))
        assertEquals(SafetyVerdict.Allow, SafetyPolicy.check(DecodedAction.Intent(IntentAction.WebSearch("x")), null, "en"))
        assertFalse(SafetyPolicy.isDialable("*100#"))
    }
}
