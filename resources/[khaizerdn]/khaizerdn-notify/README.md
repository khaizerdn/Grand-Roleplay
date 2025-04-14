# khaizerdn-notify
QBCore Notification System

## Usage
-- Basic Notification
exports['khaizerdn-notify']:ShowNotification(source, "Your message here")
exports['khaizerdn-notify']:ShowNotification(source, "This is a basic notification!", 3000)

-- Advanced Notification
exports['khaizerdn-notify']:ShowAdvancedNotification(source, "Test Title", "Test Subtitle", "This is an advanced notification!", "CHAR_DEFAULT", 1, 5000)

-- Help Notification
exports['khaizerdn-notify']:ShowHelpNotification(source, "This is a help notification! Press ~INPUT_CONTEXT~ to interact", 5000)

## Dependencies
- qb-core