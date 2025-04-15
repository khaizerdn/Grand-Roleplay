# khaizerdn-notifyV2
## Usage
Trigger notifications using exports in Lua scripts. Supports client-side and server-side calls.
Client-Side
-- Basic Notification
exports['khaizerdn-notifyV2']:ShowNotification("This is a basic notification!", 3000)

-- Advanced Notification (with image)
exports['khaizerdn-notifyV2']:ShowAdvancedNotification("Test Title", "Test Subtitle", "This is an advanced notification!", "https://via.placeholder.com/50", 5000)

-- Help Notification
exports['khaizerdn-notifyV2']:ShowHelpNotification("Press ~INPUT_CONTEXT~ to interact", 0)

-- Clear Help Notification
exports['khaizerdn-notifyV2']:ClearHelpNotification()

Server-Side
-- Basic Notification
exports['khaizerdn-notifyV2']:ShowNotification(source, "This is a basic notification!", 3000)

-- Advanced Notification (with image)
exports['khaizerdn-notifyV2']:ShowAdvancedNotification(source, "Test Title", "Test Subtitle", "This is an advanced notification!", "https://via.placeholder.com/50", 5000)

-- Help Notification
exports['khaizerdn-notifyV2']:ShowHelpNotification(source, "Press ~INPUT_CONTEXT~ to interact", 0)

-- Clear Help Notification
exports['khaizerdn-notifyV2']:ClearHelpNotification(source)

Example: qb-banking Integration
In qb-banking/client.lua, add to a zone:
combo:onPlayerInOut(function(isPointInside)
    isPlayerInsideBankZone = isPointInside
    if isPlayerInsideBankZone then
        exports['khaizerdn-notifyV2']:ShowHelpNotification("Press ~INPUT_CONTEXT~ to open bank", 0)
        -- ... interaction logic ...
    else
        exports['khaizerdn-notifyV2']:ClearHelpNotification()
    end
end)

This shows a persistent help notification that clears when leaving the zone.

Notification Types

Basic: Right-aligned text with a gold right border, top-right.
Advanced: Right-aligned title, subtitle, message, and large image with a blue right border, top-right.
Help: Large instructional text with an orange left border, top-left, non-stacking (overwrites previous).

Notes

Image URLs: Advanced notifications default to a placeholder (https://via.placeholder.com/50). Use custom URLs or local images.
Duration: Milliseconds (e.g., 3000 = 3s). Use 0 for persistent help notifications.
Dependencies: Requires qb-core.
Stacking: Basic/advanced stack with newest on top; help notifications overwrite the previous one.

Testing
Use the debug command in F8:
testnotify basic
testnotify advanced
testnotify help
testnotify clear

Troubleshooting

Notifications Not Showing:
Verify khaizerdn-notifyV2 is started and loads before dependent resources.
Check F8 console for errors.


Export Errors:
Ensure resource name is khaizerdn-notifyV2 in calls.


Clear Cache:
Delete cache folder in resources and restart server.


Logs:
Enable CEF dev tools (setr fivem CEFDevTools true) and check browser console for NUI errors.



