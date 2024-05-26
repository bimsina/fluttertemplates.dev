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
    <div className="relative h-full w-full">
      {isLoading && props.showLoadingIndicator && (
        <div className="absolute h-full w-full">
          <CircularProgress />
        </div>
      )}
      <iframe
        src={props.url}
        className={`absolute h-full w-full ${props.className}`}
      ></iframe>
    </div>
  );
}
