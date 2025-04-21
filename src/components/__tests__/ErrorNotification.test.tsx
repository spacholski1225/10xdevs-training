import { describe, it, expect } from "vitest";
import { render, screen } from "../../test/utils";
import { ErrorNotification } from "../ErrorNotification";

describe("ErrorNotification", () => {
  it("renders error message correctly", () => {
    const message = "Test error message";
    render(<ErrorNotification message={message} />);
    expect(screen.getByText(message)).toBeInTheDocument();
  });

  it("renders with destructive variant", () => {
    render(<ErrorNotification message="Test message" />);
    const alert = screen.getByRole("alert");
    expect(alert).toHaveClass("destructive");
  });

  it("includes error icon", () => {
    render(<ErrorNotification message="Test message" />);
    // The AlertCircle icon should be present with specific dimensions
    const icon = document.querySelector("svg");
    expect(icon).toBeInTheDocument();
    expect(icon).toHaveClass("h-4", "w-4");
  });
});