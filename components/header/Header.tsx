import { GITHUB_LINK } from "../../constants";
import React, { useState } from "react";
import CustomFlatButton from "../buttons/FlatButton";
import { MdClose, MdMenu } from "react-icons/md";
import ThemeChanger from "./ThemeChanger";

const Header = () => {
  const [navbarOpen, setNavbarOpen] = React.useState(false);
  return (
    <>
      <nav className="fixed flex justify-between py-4 w-full lg:px-48 md:px-12 px-4 content-center z-50 text-primary backdrop-blur-xl dark:backdrop-blur-xl bg-background dark:bg-darkBackground bg-opacity-50 dark:bg-opacity-50">
        <div className="container px-4 mx-auto flex flex-wrap items-center justify-between">
          <div className="w-full relative flex justify-between lg:w-auto lg:static lg:block lg:justify-start">
            <a
              href="/"
              className="font-extrabold inline-flex justify-center items-center"
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
              <div className="growing-underline text-primary text-xl font-bold">
                Flutter
                <span className="ml-1 text-gray-800 dark:text-gray-50">
                  Templates
                </span>
              </div>
            </a>

            <button
              className="text-primary cursor-pointer text-xl leading-none px-3 py-1 border border-solid border-transparent rounded bg-transparent block lg:hidden outline-none focus:outline-none"
              type="button"
              onClick={() => setNavbarOpen(!navbarOpen)}
            >
              {!navbarOpen ? <MdMenu /> : <MdClose />}
            </button>
          </div>
          <div
            className={
              "lg:flex flex-grow items-center" +
              (navbarOpen ? " flex" : " hidden")
            }
            id="example-navbar-danger"
          >
            <ul className="flex flex-col lg:flex-row list-none lg:ml-auto lg:justify-center lg:items-center">
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
