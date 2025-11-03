// Native messaging port
const NATIVE_APP_NAME = "open_in_systembrowser";

// Create context menu
browser.contextMenus.create({
  id: "open-in-system-browser",
  title: "Open in System Browser",
  contexts: ["link"]
});

// Handle context menu clicks
browser.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "open-in-system-browser" && info.linkUrl) {
    openInSystemBrowser(info.linkUrl);
  }
});

// Function to send URL to native messaging host
function openInSystemBrowser(url) {
  try {
    const port = browser.runtime.connectNative(NATIVE_APP_NAME);
    
    port.onMessage.addListener((response) => {
      console.log("Received response from native host:", response);
      if (response.error) {
        console.error("Native host error:", response.error);
        notifyError(response.error);
      }
    });
    
    port.onDisconnect.addListener(() => {
      if (browser.runtime.lastError) {
        console.error("Disconnected from native host:", browser.runtime.lastError.message);
        notifyError(browser.runtime.lastError.message);
      }
    });
    
    // Send URL to native host
    port.postMessage({ url: url });
  } catch (error) {
    console.error("Failed to connect to native host:", error);
    notifyError("Failed to connect to native messaging host. Please ensure it is installed.");
  }
}

// Show error notification
function notifyError(message) {
  browser.notifications.create({
    type: "basic",
    title: "Open in System Browser Error",
    message: message,
    iconUrl: browser.runtime.getURL("icons/icon-48.png")
  });
}