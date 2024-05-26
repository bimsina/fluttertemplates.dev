import { MdArrowForward } from "react-icons/md";
import React from "react";
import CustomContainedButton from "../buttons/ContainedButton";

export default function BrowseComponentsCTA() {
  return (
    <section className="m-4">
      <div className="my-10 rounded-lg bg-secondary bg-opacity-5">
        <div className="mx-auto px-4 py-12 sm:px-6 lg:flex lg:items-center lg:justify-between lg:px-8 lg:py-16">
          <h2 className="pr-10 text-3xl font-bold tracking-tight text-gray-700 dark:text-gray-200 sm:text-xl">
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
