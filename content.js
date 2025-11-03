// Handle Alt+Right-Click on links
document.addEventListener('mousedown', (event) => {
  // Check for Alt key + Right mouse button (button 2)
  if (event.altKey && event.button === 2) {
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

// Also prevent context menu from showing when Alt+Right-Click is used
document.addEventListener('contextmenu', (event) => {
  if (event.altKey) {
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
