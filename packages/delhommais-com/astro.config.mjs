// @ts-check
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
	server: {
		host: true,
	},

	vite: {
		server: {
			watch: {
				ignored: [
					"**/.astro/**",
					"**/dist/**",
					"**/node_modules/**",
					"**/.direnv/**",
					"**/result/**",
				],
			},
		},
	},
});
