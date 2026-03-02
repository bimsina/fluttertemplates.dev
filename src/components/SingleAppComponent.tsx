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
import { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { okaidia, prism } from "react-syntax-highlighter/dist/cjs/styles/prism";
import type { previewSizeEnum } from "@/types";

export default function SingleAppComponent({
  widget,
  code = [],
}: {
  widget: InferEntrySchema<"widgets">;
  code?: {
    file: string;
    content: string;
  }[];
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

  const getPreviewWidth = () => {
    switch (previewSize) {
      case "mobile":
        return "w-[375px]";
      case "tablet":
        return "w-[768px]";
      case "desktop":
        return "w-[1024px]";
    }
  };

  return (
    <Tabs className="flex w-full flex-col" defaultValue="preview">
      <div className="flex h-14 items-center justify-between rounded-md border px-4">
        <h1 className="text-base font-semibold">{widget.title}</h1>
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
          <div className={`${getPreviewWidth()} transition-all duration-300`}>
            <FlutterAppIframe
              className="aspect-9/16 h-[700px] w-full"
              path={widget.path}
            />
          </div>
        </div>
      </TabsContent>
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
                  className="bg-muted hover:bg-primary hover:text-primary-foreground absolute top-2 right-2 flex w-[130px] cursor-pointer items-center justify-center gap-2 rounded-md px-1 py-1 text-sm transition-all"
                >
                  {copied ? (
                    <Check className="size-3" />
                  ) : (
                    <Copy className="size-3" />
                  )}

                  {copied ? "Copied" : "Copy code"}
                </button>
                <div className="border-border h-full overflow-auto rounded-md border">
                  <SyntaxHighlighter
                    language="dart"
                    style={theme === "dark" ? okaidia : prism}
                    customStyle={{
                      margin: 0,
                      height: "100%",
                      borderRadius: "0.5rem",
                      background: "transparent",
                    }}
                    codeTagProps={{
                      style: { fontFamily: "var(--font-mono)" },
                    }}
                  >
                    {file.content}
                  </SyntaxHighlighter>
                </div>
              </div>
            </TabsContent>
          ))}
        </Tabs>
      </TabsContent>
    </Tabs>
  );
}
