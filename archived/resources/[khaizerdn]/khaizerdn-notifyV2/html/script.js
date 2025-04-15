window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('[khaizerdn-notifyV2] NUI received message:', JSON.stringify(data));
    const containerLeft = document.getElementById('notification-container-left');
    const containerRight = document.getElementById('notification-container-right');

    if (data.type === 'clear_help') {
        console.log('[khaizerdn-notifyV2] Clearing help notification');
        while (containerLeft.firstChild) {
            containerLeft.firstChild.remove();
        }
        return;
    }

    const container = data.type === 'help' ? containerLeft : containerRight;

    if (!container) {
        console.error('[khaizerdn-notifyV2] Container not found for type:', data.type);
        return;
    }

    // Clear existing help notification
    if (data.type === 'help') {
        while (container.firstChild) {
            container.firstChild.remove();
        }
        // Play sound for help notification
        const audio = new Audio('sounds/notify.mp3');
        audio.play().catch(err => console.error('[khaizerdn-notifyV2] Audio playback failed:', err));
    }

    const notification = document.createElement('div');
    notification.className = `notification ${data.type}`;

    if (data.type === 'advanced') {
        notification.innerHTML = `
            <div class="image-container" style="background-image: url(${data.image})"></div>
            <div class="text-container">
                <div class="title">${data.title || 'Notification'}</div>
                <div class="subtitle">${data.subtitle || ''}</div>
                <div class="message">${data.message}</div>
            </div>
        `;
    } else {
        notification.innerHTML = `<div class="message">${data.message}</div>`;
    }

    // Prepend for basic/advanced, append for help to ensure single notification
    if (data.type === 'help') {
        container.append(notification);
    } else {
        container.prepend(notification);
    }

    // Only set timeout for non-help notifications or if duration is specified
    if (data.type !== 'help' || data.duration > 0) {
        setTimeout(() => {
            notification.classList.add('hide');
            setTimeout(() => {
                notification.remove();
                console.log('[khaizerdn-notifyV2] Notification removed');
                fetch(`https://${GetParentResourceName()}/hideNotification`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }, 300); // Match fade-out duration
        }, data.duration || 5000);
    }
});