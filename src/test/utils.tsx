import { cleanup, render } from "@testing-library/react";
import { afterEach } from "vitest";
import type { RenderOptions } from "@testing-library/react";
import type { ReactElement } from "react";
import * as matchers from "@testing-library/jest-dom/matchers";
import { expect } from "vitest";

// Extend Vitest's expect with Testing Library matchers
expect.extend(matchers);

// Automatically cleanup after each test
afterEach(() => {
  cleanup();
});

function customRender(
  ui: ReactElement,
  options: Omit<RenderOptions, "wrapper"> = {},
) {
  return render(ui, {
    // Add global providers here if needed
    // wrapper: ({ children }) => (
    //   <SomeProvider>{children}</SomeProvider>
    // ),
    ...options,
  });
}

// Re-export everything
export * from "@testing-library/react";

// Override render method
export { customRender as render };