import React from "react";
import HomePageHead from "@/head/SEOHead";
import Footer from "@/components/footer/Footer";

export default function PageNotFoundPage() {
  return (
    <>
      <HomePageHead title="404 : Cant find the page you're looking for." />
      <div className="flex h-screen items-center justify-center bg-secondary bg-opacity-5">
        <div className="flex flex-col items-center">
          <h1 className="text-9xl font-bold text-primary">404</h1>

          <h6 className="mb-2 text-center text-2xl font-bold text-gray-800 dark:text-gray-300 md:text-3xl">
            <span className="text-red-500">Oops!</span> Page not found
          </h6>

          <p className="mb-8 text-center text-gray-500 md:text-lg">
            The page you’re looking for doesn’t exist.
          </p>

          <a
            href="/"
            className="rounded-lg border-2 border-primary  px-8 py-4 font-semibold text-primary"
          >
            Go home
          </a>
        </div>
      </div>
      <Footer />
    </>
  );
}
