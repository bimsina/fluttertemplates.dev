import { useTheme } from "next-themes";
import { BiMoon, BiSun } from "react-icons/bi";
import { useState, useEffect, useRef } from "react";
import { MdDesktopMac } from "react-icons/md";

function useComponentVisible(initialIsVisible: boolean) {
  const [isComponentVisible, setIsComponentVisible] =
    useState(initialIsVisible);
  const ref = useRef<HTMLDivElement>(null);

  const handleHideDropdown = (event: KeyboardEvent) => {
    if (event.key === "Escape") {
      setIsComponentVisible(false);
    }
  };

  const handleClickOutside = (event: Event) => {
    if (ref.current && !ref.current.contains(event.target as Node)) {
      setIsComponentVisible(false);
    }
  };

  useEffect(() => {
    document.addEventListener("keydown", handleHideDropdown, true);
    document.addEventListener("click", handleClickOutside, true);
    return () => {
      document.removeEventListener("keydown", handleHideDropdown, true);
      document.removeEventListener("click", handleClickOutside, true);
    };
  });

  return { ref, isComponentVisible, setIsComponentVisible };
}
interface ThemeOption {
  icon: JSX.Element;
  value: string;
}

const _themeOptions: ThemeOption[] = [
  {
    icon: <BiMoon />,
    value: "dark",
  },
  {
    icon: <BiSun />,
    value: "light",
  },
  {
    icon: <MdDesktopMac />,
    value: "system",
  },
];

const ThemeChanger = () => {
  const { systemTheme, theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  const themeButton = useRef(null);

  useEffect(() => {
    setMounted(true);
  }, []);

  const { ref, isComponentVisible, setIsComponentVisible } =
    useComponentVisible(false);

  const renderThemeChanger = () => {
    if (!mounted)
      return (
        <div className="ml-2 h-8 w-8 rounded-md bg-card dark:bg-darkCard">
          <MdDesktopMac />
        </div>
      );

    const currentTheme = theme === "system" ? systemTheme : theme;

    return (
      <div
        ref={ref}
        className="group relative ml-2 inline-block h-8 w-8 items-center justify-center rounded-md bg-card text-lg text-black dark:bg-darkCard dark:text-white"
      >
        <div className="inline-flex h-full w-full items-center justify-center">
          <button
            onClick={() => {
              setIsComponentVisible(!isComponentVisible);
            }}
            ref={themeButton}
          >
            {theme === "system" ? (
              <MdDesktopMac />
            ) : currentTheme === "dark" ? (
              <BiMoon />
            ) : (
              <BiSun />
            )}
          </button>
        </div>
        <ul
          className={`${
            isComponentVisible ? "block" : "hidden"
          } text-md absolute z-10 mt-2  rounded-lg bg-card p-2 pt-1 text-gray-700 shadow-lg dark:bg-darkCard dark:text-gray-200 lg:-ml-32`}
        >
          <li>
            {_themeOptions.map((item) => (
              <button
                key={item.value}
                className="whitespace-no-wrap flex w-36 items-center gap-4 rounded-sm px-4 py-2 text-left capitalize hover:bg-background hover:bg-opacity-10 dark:hover:bg-darkBackground dark:hover:bg-opacity-10"
                onClick={() => {
                  setTheme(item.value);
                  setIsComponentVisible(!isComponentVisible);
                }}
              >
                {item.icon}
                <span className="text-sm"> {item.value}</span>
              </button>
            ))}
          </li>
        </ul>
      </div>
    );
  };

  return <div>{renderThemeChanger()}</div>;
};

export default ThemeChanger;
