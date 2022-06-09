import { MdArrowForward } from "react-icons/md";
import React from "react";
import CustomContainedButton from "../buttons/ContainedButton";

export default function BrowseComponentsCTA() {
  return (
    <section className="m-4">
      <div className="bg-secondary bg-opacity-5 my-10 rounded-lg">
        <div className="mx-auto py-12 px-4 sm:px-6 lg:py-16 lg:px-8 lg:flex lg:items-center lg:justify-between">
          <h2 className="text-3xl font-bold tracking-tight text-gray-700 dark:text-gray-200 sm:text-xl pr-10">
            Explore production ready Flutter Widgets and Templates
          </h2>
          <div className="mt-8 flex lg:mt-0 lg:flex-shrink-0">
            <CustomContainedButton
              label="Browse Widgets"
              href="/widgets"
              endIcon={<MdArrowForward fontSize="small" />}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
