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
import {
  oneDark,
  oneLight,
} from "react-syntax-highlighter/dist/cjs/styles/prism";
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
    <Tabs className="flex flex-col w-full" defaultValue="preview">
      <div className="border rounded-md h-14 flex items-center justify-between px-4">
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
              className="h-[700px] aspect-[9/16] w-full"
              path={widget.path}
            />
          </div>
        </div>
      </TabsContent>
      <TabsContent value="code">
        <Tabs defaultValue={code[0].file}>
          <TabsList className="flex items-center gap-2">
            {code.map((file) => (
              <TabsTrigger key={file.file} value={file.file}>
                {file.file}
              </TabsTrigger>
            ))}
          </TabsList>

          {code.map((file) => (
            <TabsContent key={file.file} value={file.file}>
              <div className="relative h-[700px]">
                <button
                  onClick={() => handleCopy(file.content)}
                  className="absolute top-2 right-2 p-2 rounded-md bg-muted hover:bg-primary hover:text-primary-foreground flex items-center gap-2 w-[130px] justify-center transition-all cursor-pointer"
                >
                  {copied ? (
                    <Check className="w-4 h-4" />
                  ) : (
                    <Copy className="w-4 h-4" />
                  )}

                  {copied ? "Copied" : "Copy code"}
                </button>
                <div className="rounded-md h-full overflow-auto">
                  <SyntaxHighlighter
                    language="dart"
                    style={theme === "dark" ? oneDark : oneLight}
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
