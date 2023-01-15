import Footer from "@/components/footer/Footer";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import WidgetsList from "@/components/widgetsPageSections/WidgetsList";
import WidgetPageHead from "@/head/WidgetPageHead";
import { WidgetGroup, WidgetsResponse, Widgetsubgroup } from "@/models/widget";
import { CustomPost } from "@/utils/widgets/helper";
import { AnimatePresence, motion } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import { MdArrowDropDown } from "react-icons/md";

export default function WidgetsListPage({
  postData,
  componentsResponse,
}: {
  postData: CustomPost;
  componentsResponse: WidgetsResponse;
}) {
  const [selectedSubGroup, setSelectedSubGroup] =
    useState<Widgetsubgroup | null>();

  const [selectedGroup, setSelectedGroup] = useState<WidgetGroup | null>();

  const router = useRouter();

  const { group, subGroup } = router.query;

  useEffect(() => {
    const _groupIndex = Math.max(
      0,
      componentsResponse.widget_groups.findIndex((val) => val.id === group)
    );

    const _selectedGroup = componentsResponse.widget_groups[_groupIndex];

    setSelectedGroup(_selectedGroup);

    const _subGroupIndex = Math.max(
      0,
      _selectedGroup.widget_subgroups.findIndex(
        (val) => val.id === _selectedGroup.id + "/" + subGroup
      )
    );

    const _selectedSubGroup =
      componentsResponse.widget_groups[_groupIndex].widget_subgroups[
        _subGroupIndex
      ];

    setSelectedSubGroup(_selectedSubGroup);

    // just a fix for not scrolling into section on load
    // find what's causing the issue and remove this
    const _pathWithSectionId = router.asPath.split("#");
    if (_pathWithSectionId.length === 2) {
      setTimeout(() => {
        const id = _pathWithSectionId.pop();

        if (!id) return;

        document.getElementById(id)?.scrollIntoView({
          behavior: "smooth",
        });
      }, 100);
    }
  }, [group, subGroup]);

  return (
    <>
      <WidgetPageHead
        title={postData.frontmatter.title}
        description={`${
          postData.frontmatter.description
            ? postData.frontmatter.description + " - "
            : ""
        }${selectedSubGroup?.widgets
          .map((item) => item.description)
          .join(" ")}`}
      />

      <div className="inline-flex w-full justify-center px-8">
        <div className="flex w-full max-w-[100rem]">
          {leftSideBar()}
          <div className="flex-1 w-full ml-56">
            {selectedGroup && selectedSubGroup && (
              <WidgetsList componentSubgroup={selectedSubGroup} />
            )}

            <SubmitProposalSection />

            <Footer />
          </div>
        </div>
      </div>
    </>
  );

  function leftSideBar() {
    return (
      <aside className="w-56 h-screen overflow-y-auto flex flex-col fixed pr-3 pb-24 border-r border-borderColor dark:border-darkBorderColor">
        {componentsResponse.widget_groups.map((grp) => (
          <_LeftSizeBarGroupItem
            key={`group_${grp.id}`}
            group={grp}
            expanded={true}
            selectedSubGroup={subGroup ? subGroup.toString() : undefined}
          />
        ))}
      </aside>
    );
  }
}

const _LeftSizeBarGroupItem = ({
  group,
  expanded = false,
  selectedSubGroup,
}: {
  group: WidgetGroup;
  expanded?: boolean;
  selectedSubGroup?: string | undefined;
}) => {
  const [isExpanded, setIsExpanded] = useState(expanded);
  return (
    <div className="flex flex-col">
      <div
        className="flex cursor-pointer"
        onClick={() => {
          setIsExpanded(!isExpanded);
        }}
      >
        <div className="flex-1 text-md font-semibold">{group.title}</div>
        <motion.div
          animate={{
            rotate: isExpanded ? 180 : 0,
          }}
          className="w-8 h-8 flex justify-center items-center text-2xl"
        >
          <MdArrowDropDown />
        </motion.div>
      </div>

      <AnimatePresence initial={false}>
        {isExpanded && (
          <motion.section
            key={`group_${group.id}`}
            className="ml-2"
            initial="collapsed"
            animate="open"
            exit="collapsed"
            variants={{
              open: { opacity: 1, height: "auto" },
              collapsed: { opacity: 0, height: 0 },
            }}
            transition={{ duration: 0.2, ease: [0.04, 0.62, 0.23, 0.98] }}
          >
            <div className="flex flex-col border-b mb-4 dark:border-darkBorderColor border-borderColor">
              {group.widget_subgroups.map((sub_group) => (
                <_LeftSizeBarSubGroupItem
                  key={`subgroup_item_${sub_group.id}`}
                  sub_group={sub_group}
                  expanded={selectedSubGroup === sub_group.id.split("/").pop()}
                />
              ))}
            </div>
          </motion.section>
        )}
      </AnimatePresence>
    </div>
  );
};

const _LeftSizeBarSubGroupItem = ({
  sub_group,
  expanded = false,
}: {
  sub_group: Widgetsubgroup;
  expanded?: boolean;
}) => {
  const [isExpanded, setIsExpanded] = useState(expanded);
  return (
    <div className="flex flex-col">
      <Link href={`/widgets/${sub_group.id}`} className="flex">
        <div className="flex-1 text-gray-700 dark:text-gray-300">
          {sub_group.title}
        </div>
        <motion.button
          animate={{
            rotate: isExpanded ? 180 : 0,
          }}
          onClick={() => {
            setIsExpanded(!isExpanded);
          }}
          className="w-8 h-8 flex justify-center items-center text-2xl"
        >
          <MdArrowDropDown />
        </motion.button>
      </Link>

      <AnimatePresence initial={false}>
        {isExpanded && (
          <motion.section
            key={`sub_group_${sub_group.id}`}
            className="ml-2"
            initial="collapsed"
            animate="open"
            exit="collapsed"
            variants={{
              open: { opacity: 1, height: "auto" },
              collapsed: { opacity: 0, height: 0 },
            }}
            transition={{ duration: 0.2, ease: [0.04, 0.62, 0.23, 0.98] }}
          >
            <div className="flex flex-col pb-2 mb-4">
              {sub_group.widgets.map((widget) => {
                const id = widget.id.split("/").pop();
                return (
                  <Link
                    className="text-gray-800 dark:text-gray-400 text-sm py-1 border-l pl-2 dark:border-transparent border-transparent hover:border-primary dark:hover:border-primary"
                    key={`widget_${widget.id}`}
                    href={`/widgets/${sub_group.id}#${id}`}
                    scroll={false}
                  >
                    {widget.title}
                  </Link>
                );
              })}
            </div>
          </motion.section>
        )}
      </AnimatePresence>
    </div>
  );
};
