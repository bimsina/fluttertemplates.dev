import React from "react";
import { MdLink } from "react-icons/md";

interface Props {
  packages?: string[];
}

export default function PackagesUsed({ packages = [] }: Props) {
  return (
    <div className="flex h-[80%] w-full flex-col items-center justify-center overflow-y-auto p-8">
      {packages.length === 0 && (
        <img
          src="/no_packages.svg"
          alt="No Packages Used"
          className="h-[30vh]"
        />
      )}
      {packages.length === 0 && <h4 className="font-bold">No Packages Used</h4>}

      {packages.map((packageName) => (
        <div key={packageName}>
          <a
            href={packageName}
            target="_blank"
            rel="noopener noreferrer"
            style={{
              color: "transparent",
            }}
          >
            <button className="flex flex-row items-center justify-center p-2 text-blue-400">
              <MdLink
                fontSize="small"
                style={{
                  marginRight: "8px",
                }}
              />
              {packageName.split("/").pop()?.toLowerCase()}
              <img
                src={`https://img.shields.io/pub/v/${packageName
                  .split("/")
                  .pop()}.svg`}
                alt={packageName}
                style={{
                  marginLeft: "8px",
                }}
              />
            </button>
          </a>
        </div>
      ))}
    </div>
  );
}
