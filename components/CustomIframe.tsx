import React, { useEffect } from "react";
import CircularProgress from "./shared/CircularProgress";
interface CustomIframeProps {
  url: string;
  showLoadingIndicator: boolean;
  className?: string | undefined;
}

export default function CustomIframe(props: CustomIframeProps) {
  const [isLoading, setIsLoading] = React.useState(true);

  useEffect(() => {
    startLoading();
  }, []);

  function awaitFor10s(x: number) {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(x);
      }, 10000);
    });
  }

  async function startLoading() {
    var x = await awaitFor10s(10);
    setIsLoading(false);
  }

  return (
    <div className="relative w-full h-full">
      {isLoading && props.showLoadingIndicator && (
        <div className="w-full h-full absolute">
          <CircularProgress />
        </div>
      )}
      <iframe
        src={props.url}
        className={`w-full h-full absolute ${props.className}`}
      ></iframe>
    </div>
  );
}
