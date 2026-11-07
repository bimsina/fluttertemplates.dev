import FlutterAppIframe from "./FlutterAppIframe";

// Embeds a running widget inside a guide.
export default function LivePreview({ path }: { path: string }) {
  return (
    <div className="not-prose mx-auto my-8 w-full max-w-[375px]">
      <FlutterAppIframe className="h-[640px] w-full rounded-[14px]" path={path} />
    </div>
  );
}
