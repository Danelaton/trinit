import type { ExtensionMessage } from "@roo-code/types"

/** Notifies the webview that Trinit Gateway credentials are available for model discovery. */
export function postZooGatewayCredentialsReady(postMessage: (message: ExtensionMessage) => void): void {
	postMessage({ type: "zooGatewayCredentialsReady" })
}
