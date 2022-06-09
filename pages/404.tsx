import React from "react";
import HomePageHead from "@/head/SEOHead";

export default function PageNotFoundPage() {
  return (
    <>
      <HomePageHead title="404 : Cant find the page you're looking for." />
      <div className="flex items-center justify-center w-screen h-screen bg-secondary bg-opacity-5">
        <div className="flex flex-col items-center">
          <h1 className="font-bold text-primary text-9xl">404</h1>

          <h6 className="mb-2 text-2xl font-bold text-center text-gray-800 md:text-3xl">
            <span className="text-red-500">Oops!</span> Page not found
          </h6>

          <p className="mb-8 text-center text-gray-500 md:text-lg">
            The page you’re looking for doesn’t exist.
          </p>

          <a
            href="/"
            className="px-8 py-4 font-semibold  rounded-lg text-primary border-primary border-2"
          >
            Go home
          </a>
        </div>
      </div>
    </>
  );
}
