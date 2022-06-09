import { MdMailOutline } from "react-icons/md";
import { GrTwitter, GrLinkedin } from "react-icons/gr";
import { BUY_ME_A_COFFEE_LINK } from "../../constants";

export default function Footer() {
  return (
    <footer className="bg-background dark:bg-darkBackground text-gray-900 dark:text-gray-50">
      <div className="px-4 pt-16 mx-auto sm:max-w-xl md:max-w-full md:px-24 lg:px-8">
        <div className="flex flex-row justify-center items-center">
          <div className="flex flex-col items-center p-4">
            <p className="text-base font-bold tracking-wide  mb-4">
              Support Us
            </p>
            <a
              href={BUY_ME_A_COFFEE_LINK}
              target="_blank"
              rel="noopener noreferrer"
            >
              <img
                src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
                alt="Buy Me A Coffee"
                className="h-14"
              />
            </a>
          </div>
          <div className="flex flex-col items-center p-4">
            <p className="text-base font-bold tracking-wide  mb-4">Contact</p>
            <div className="grid grid-cols-3 gap-2 text-gray-700 dark:text-gray-200">
              <a
                href="mailto:timsinabibek960@gmail.com"
                target="_blank"
                referrerPolicy="no-referrer"
              >
                <MdMailOutline size={24} />
              </a>

              <a
                href="https://twitter.com/bimsina"
                target="_blank"
                referrerPolicy="no-referrer"
              >
                <GrTwitter size={24} />
              </a>

              <a
                href="https://www.linkedin.com/in/bimsina/"
                target="_blank"
                referrerPolicy="no-referrer"
              >
                <GrLinkedin size={24} />
              </a>
            </div>
          </div>
        </div>
        <div className="flex flex-row justify-center py-8 border-t dark:border-gray-600 border-gray-200">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Made by
            <a
              href="https://twitter.com/bimsina"
              target="_blank"
              rel="noopener noreferrer"
              style={{
                margin: "0 0.25rem",
              }}
            >
              Bibek Timsina
            </a>
            and
            <a
              href="https://github.com/bimsina/fluttertemplates.dev/graphs/contributors"
              target="_blank"
              rel="noopener noreferrer"
              style={{ marginLeft: "0.25rem" }}
            >
              contributors
            </a>
          </p>
        </div>
      </div>
    </footer>
  );
}
