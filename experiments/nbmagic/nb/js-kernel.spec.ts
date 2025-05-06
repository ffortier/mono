import { assertEquals } from "jsr:@std/assert";

Deno.test({
  name: "first",
  fn: () => {
    assertEquals(true, true);
  },
});
