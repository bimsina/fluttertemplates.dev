import React, { useEffect } from "react";
import CircularProgress from "./shared/CircularProgress";
interface CustomIframeProps {
  url: string;
  style?: React.CSSProperties;
  showLoadingIndicator: boolean;
  className?: string | undefined;
}

export default function CustomIframe(props: CustomIframeProps) {
  const [isLoading, setIsLoading] = React.useState(true);

  useEffect(() => {
    setTimeout(() => {
      setIsLoading(false);
    }, 10000);
  }, []);

  return (
    <div
      className={props.className}
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
      }}
    >
      {isLoading && props.showLoadingIndicator && (
        <div className="w-full h-full absolute">
          <CircularProgress />
        </div>
      )}
      <iframe
        src={props.url}
        style={{
          height: "100%",
          width: "100%",
          position: "absolute",
          border: "none",
          ...props.style,
        }}
      ></iframe>
    </div>
  );
}
