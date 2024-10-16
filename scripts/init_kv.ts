import { cecho, KEY } from "./shared.ts";

const kv = await Deno.openKv();
const initCheck = await kv.get(KEY);
if (initCheck.value === null) {
  cecho("doing", "kv store is empty, setting initial store");
  await kv.set(KEY, {
    currIndex: 0,
    stack: [],
  });
} else {
  cecho("noop", "kv store is populated");
}