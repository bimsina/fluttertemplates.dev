import type { InferEntrySchema, z } from "astro:content";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import {
  Code as CodeIcon,
  Eye,
  Smartphone,
  Tablet,
  Laptop,
  Copy,
  Check,
} from "lucide-react";
import FlutterAppIframe from "./FlutterAppIframe";
import { lazy, Suspense, useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import type { previewSizeEnum } from "@/types";

const CodeHighlighter = lazy(() => import("./CodeHighlighter"));

const PREVIEW_DIMENSIONS = {
  mobile: { width: 375, height: 700 },
  tablet: { width: 768, height: 700 },
  desktop: { width: 1024, height: 700 },
} as const;

export default function SingleAppComponent({
  widget,
  code = [],
  hideTitle = false,
}: {
  widget: InferEntrySchema<"widgets">;
  code?: {
    file: string;
    content: string;
  }[];
  hideTitle?: boolean;
}) {
  const theme = useTheme();
  const [previewSize, setPreviewSize] = useState<
    z.infer<typeof previewSizeEnum>
  >(widget.previewSize);
  const [copied, setCopied] = useState(false);

  const handleCopy = (content: string) => {
    navigator.clipboard.writeText(content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const previewDimensions = PREVIEW_DIMENSIONS[previewSize];

  return (
    <Tabs className="flex w-full flex-col" defaultValue="preview">
      <div
        className={`mb-5 flex items-center gap-4 ${hideTitle ? "justify-end" : "justify-between"}`}
      >
        {!hideTitle && (
          <h2 className="text-lg font-semibold tracking-tight">
            {widget.title}
          </h2>
        )}
        <TabsList className="flex items-center gap-2">
          <TabsTrigger value="preview">
            <Eye />
            Preview
          </TabsTrigger>
          {code.length > 0 && (
            <TabsTrigger value="code">
              <CodeIcon />
              Code
            </TabsTrigger>
          )}
        </TabsList>
      </div>
      <TabsContent value="preview">
        <div className="flex flex-col items-center gap-4">
          <Tabs
            value={previewSize}
            onValueChange={(value) =>
              setPreviewSize(value as "mobile" | "tablet" | "desktop")
            }
          >
            <TabsList className="flex items-center gap-2">
              <TabsTrigger value="mobile">
                <Smartphone />
              </TabsTrigger>
              <TabsTrigger value="tablet">
                <Tablet />
              </TabsTrigger>
              <TabsTrigger value="desktop">
                <Laptop />
              </TabsTrigger>
            </TabsList>
          </Tabs>
          <div
            className="mx-auto min-h-[700px] max-w-full transition-[width] duration-300"
            style={{ width: `min(100%, ${previewDimensions.width}px)` }}
          >
            <FlutterAppIframe
              className="h-[700px] w-full"
              path={widget.path}
              enableShowFullScreenButton
              fullScreenButtonLabel="Open in full screen"
            />
          </div>
        </div>
      </TabsContent>
      {code.length > 0 && (
        <TabsContent value="code">
          <Tabs defaultValue={code[0].file}>
            {code.length > 1 && (
              <TabsList className="flex items-center gap-2">
                {code.map((file) => (
                  <TabsTrigger key={file.file} value={file.file}>
                    {file.file}
                  </TabsTrigger>
                ))}
              </TabsList>
            )}

            {code.map((file) => (
              <TabsContent key={file.file} value={file.file}>
                <div className="relative h-[700px]">
                  <button
                    onClick={() => handleCopy(file.content)}
                    className="bg-background hover:bg-primary hover:text-primary-foreground absolute top-3 right-3 z-10 flex w-[130px] cursor-pointer items-center justify-center gap-2 rounded-lg px-1 py-1.5 text-sm transition-colors"
                  >
                    {copied ? (
                      <Check className="size-3" />
                    ) : (
                      <Copy className="size-3" />
                    )}

                    {copied ? "Copied" : "Copy code"}
                  </button>
                  <div className="bg-muted/50 h-full overflow-auto rounded-xl">
                    <Suspense
                      fallback={
                        <pre className="text-muted-foreground h-full overflow-auto p-4 font-mono text-sm">
                          Loading code...
                        </pre>
                      }
                    >
                      <CodeHighlighter content={file.content} theme={theme} />
                    </Suspense>
                  </div>
                </div>
              </TabsContent>
            ))}
          </Tabs>
        </TabsContent>
      )}
    </Tabs>
  );
}
