import { WidgetGroup, Widgetsubgroup } from "@/models/widget";
import { ExpandLess, ExpandMore } from "@mui/icons-material";
import {
  Grid,
  IconButton,
  List,
  ListItem,
  Typography,
  useTheme,
} from "@mui/material";
import { Box } from "@mui/system";
import Link from "next/link";
import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";

const drawerWidth = 220;

interface WidgetSidebarProps {
  widgetGroups: WidgetGroup[];
  selectedSubGroup?: Widgetsubgroup;
  onSubGroupSelected: (subGroup: Widgetsubgroup) => void;
}
function WidgetsSidebar(props: WidgetSidebarProps) {
  return (
    <div
      style={{
        width: `${drawerWidth}px`,
        marginTop: "3rem",
      }}
    >
      <List>
        {props.widgetGroups.map((group, index) => (
          <div key={`group_${index}`}>
            <Typography
              variant="body1"
              style={{
                fontWeight: "bold",
              }}
            >
              {group.title}
            </Typography>
            <SubGroupRenderer
              key={`subgroup_${group}`}
              group={group}
              selectedSubGroup={props.selectedSubGroup}
            />
          </div>
        ))}
      </List>
    </div>
  );
}

interface SubGroupRendererProps {
  group: WidgetGroup;
  selectedSubGroup?: Widgetsubgroup;
}

function SubGroupRenderer(props: SubGroupRendererProps) {
  const theme = useTheme();
  return (
    <List>
      {props.group.widget_subgroups.map((subgroup, index) => (
        <SingleSubGroupRenderer
          subgroup={subgroup}
          selectedSubGroup={props.selectedSubGroup}
        />
      ))}
    </List>
  );
}

interface SingleSubGroupRendererProps {
  subgroup: Widgetsubgroup;
  selectedSubGroup?: Widgetsubgroup;
}

function SingleSubGroupRenderer(props: SingleSubGroupRendererProps) {
  const theme = useTheme();

  const [expanded, setExpanded] = useState(false);
  const [isSelected, setIsSelected] = useState(false);

  const handleChange = () => {
    setExpanded(!expanded);
  };
  useEffect(() => {
    setExpanded(props.selectedSubGroup?.id === props.subgroup.id);
    setIsSelected(props.selectedSubGroup?.id === props.subgroup.id);
  }, [props.selectedSubGroup]);

  return (
    <>
      <Grid
        container
        style={{
          borderRadius: `0 1rem 1rem 0`,
          backgroundColor: isSelected
            ? `${theme.palette.secondary.main}10`
            : "",
        }}
      >
        <Box sx={{ flexGrow: 1 }}>
          <Link
            href={`/widgets/${props.subgroup.id}`}
            replace
            key={`sub_group_${props.subgroup.id}`}
          >
            <a>
              <ListItem
                button
                style={{
                  borderRadius: "0 1rem 1rem 0",
                }}
              >
                <Typography
                  variant="body2"
                  style={{
                    color: isSelected ? theme.palette.secondary.main : "",
                  }}
                >
                  {props.subgroup.title}
                </Typography>
              </ListItem>
            </a>
          </Link>
        </Box>
        <Grid item>
          <IconButton onClick={() => handleChange()}>
            {expanded ? <ExpandLess /> : <ExpandMore />}
          </IconButton>
        </Grid>
      </Grid>

      <AnimatePresence initial={false}>
        {expanded && (
          <motion.section
            key="content"
            initial="collapsed"
            animate="open"
            exit="collapsed"
            variants={{
              open: { opacity: 1, height: "auto" },
              collapsed: { opacity: 0, height: 0 },
            }}
          >
            <div
              style={{
                marginLeft: "1rem",
                borderRadius: "0 0 1rem 1rem",
              }}
            >
              {props.subgroup.widgets.map((widget, index) => (
                <Link
                  href={
                    isSelected
                      ? `#${widget.id.split("/").slice(-1)[0]}`
                      : `/widgets/${props.subgroup.id}#${
                          widget.id.split("/").slice(-1)[0]
                        }`
                  }
                  replace={!isSelected}
                  scroll={true}
                  key={`sub_group_${props.subgroup.id}_widget_${index}`}
                >
                  <a>
                    <ListItem
                      button
                      style={{
                        borderRadius: "1rem",
                      }}
                    >
                      <Typography variant="body2">
                        {index + 1}. {widget.title}
                      </Typography>
                    </ListItem>
                  </a>
                </Link>
              ))}
            </div>
          </motion.section>
        )}
      </AnimatePresence>
    </>
  );
}

export default WidgetsSidebar;
