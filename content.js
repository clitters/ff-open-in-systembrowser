// Handle Alt+Middle-Click on links
document.addEventListener('mousedown', (event) => {
  // Check for Alt key + Middle mouse button (button 1)
  if (event.altKey && event.button === 1) {
    // Find the closest link element
    let target = event.target;
    while (target && target.tagName !== 'A') {
      target = target.parentElement;
    }
    
    // If we found a link with an href
    if (target && target.href) {
      event.preventDefault();
      event.stopPropagation();
      
      // Send message to background script to open in system browser
      browser.runtime.sendMessage({
        action: 'openInSystemBrowser',
        url: target.href
      });
      
      return false;
    }
  }
}, true); // Use capture phase to intercept before other handlers

// Also prevent default middle-click behavior when Alt is pressed
document.addEventListener('click', (event) => {
  if (event.altKey && event.button === 1) {
    // Check if this is on a link
    let target = event.target;
    while (target && target.tagName !== 'A') {
      target = target.parentElement;
    }
    
    if (target && target.href) {
      event.preventDefault();
      event.stopPropagation();
      return false;
    }
  }
}, true);
