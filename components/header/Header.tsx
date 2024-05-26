import { GITHUB_LINK } from "../../constants";
import React, { useState } from "react";
import CustomFlatButton from "../buttons/FlatButton";
import { MdClose, MdMenu } from "react-icons/md";
import ThemeChanger from "./ThemeChanger";

const Header = () => {
  const [navbarOpen, setNavbarOpen] = React.useState(false);
  return (
    <>
      <nav className="fixed z-50 flex w-full content-center justify-between bg-background bg-opacity-50 px-4 py-4 text-primary backdrop-blur-xl dark:bg-darkBackground dark:bg-opacity-50 dark:backdrop-blur-xl md:px-12 lg:px-48">
        <div className="container mx-auto flex flex-wrap items-center justify-between px-4">
          <div className="relative flex w-full justify-between lg:static lg:block lg:w-auto lg:justify-start">
            <a
              href="/"
              className="inline-flex items-center justify-center font-extrabold"
            >
              <img
                src="/favicon.svg"
                alt="Flutter UI Templates Logo"
                style={{
                  height: "2.5rem",
                  width: "2.5rem",
                  paddingRight: "0.5rem",
                }}
              />
              <div className="growing-underline text-xl font-bold text-primary">
                Flutter
                <span className="ml-1 text-gray-800 dark:text-gray-50">
                  Templates
                </span>
              </div>
            </a>

            <button
              className="block cursor-pointer rounded border border-solid border-transparent bg-transparent px-3 py-1 text-xl leading-none text-primary outline-none focus:outline-none lg:hidden"
              type="button"
              onClick={() => setNavbarOpen(!navbarOpen)}
            >
              {!navbarOpen ? <MdMenu /> : <MdClose />}
            </button>
          </div>
          <div
            className={
              "flex-grow items-center lg:flex" +
              (navbarOpen ? " flex" : " hidden")
            }
            id="example-navbar-danger"
          >
            <ul className="flex list-none flex-col lg:ml-auto lg:flex-row lg:items-center lg:justify-center">
              {commonNav.map((item, idx) => (
                <li key={`nav_menu_${idx}`} className="m-2">
                  {item}
                </li>
              ))}
              <ThemeChanger />
            </ul>
          </div>
        </div>
      </nav>
    </>
  );
};

export default Header;

const commonNav = [
  <CustomFlatButton href="/widgets" label="Widgets" />,
  <CustomFlatButton href="/templates" label="Templates" />,
  <a
    href={GITHUB_LINK}
    target="_blank"
    rel="noopener noreferrer"
    className="items-center text-sm text-gray-900 hover:text-primary dark:text-gray-50 dark:hover:text-primary"
  >
    GitHub
  </a>,
];
