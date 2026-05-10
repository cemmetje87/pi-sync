/**
 * Pi Sync Extension
 *
 * Securely syncs Pi configuration (skills, extensions, settings).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

export default function piSyncExtension(pi: ExtensionAPI) {
	function getScriptPath(): string {
		return `${process.env.HOME}/.pi/agent/extensions/pi-sync/sync.sh`;
	}

	async function runSync(args: string[]): Promise<string> {
		try {
			const { stdout, stderr } = await execAsync(`bash ${getScriptPath()} ${args.join(" ")}`);
			return stdout || stderr;
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			throw new Error(`Sync failed: ${message}`);
		}
	}

	// Register sync:export tool
	pi.registerTool({
		name: "pi_sync_export",
		label: "Export Pi Config",
		description: "Export encrypted Pi configuration to file",
		parameters: Type.Object({
			target: Type.Optional(Type.String({ description: "Target file path (default: ~/pi-sync.age)" })),
		}),
		async execute(_toolCallId, params) {
			const target = params.target || "~/pi-sync.age";
			const result = await runSync(["export", target]);
			return { content: [{ type: "text", text: result }] };
		},
	});

	// Register sync:import tool
	pi.registerTool({
		name: "pi_sync_import",
		label: "Import Pi Config",
		description: "Import encrypted Pi configuration from file",
		parameters: Type.Object({
			source: Type.String({ description: "Source file path" }),
		}),
		async execute(_toolCallId, params) {
			const result = await runSync(["import", params.source]);
			return { content: [{ type: "text", text: result }] };
		},
	});
}