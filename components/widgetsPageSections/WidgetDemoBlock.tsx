import {
  Button,
  Grid,
  IconButton,
  Tab,
  Tabs,
  Typography,
  useTheme,
} from "@material-ui/core";
import {
  DesktopMacRounded,
  GitHub,
  OpenInNewRounded,
  PhoneAndroidRounded,
  TabletAndroidRounded,
} from "@material-ui/icons";
import React from "react";
import CodeBlock from "../shared/CodeBlock";
import { motion } from "framer-motion";
import CustomIframe from "../CustomIframe";

interface WidgetDemoBlockProps {
  demoUrl: string;
  rawCodeUrl: string;
  codeUrl: string;
  title: string;
}
interface ResponsiveProp {
  value: string;
  icon: JSX.Element;
  label: string;
}

const _responsiveValues: ResponsiveProp[] = [
  {
    label: "Mobile",
    value: "400px",
    icon: <PhoneAndroidRounded />,
  },
  {
    label: "Tablet",
    value: "650px",
    icon: <TabletAndroidRounded />,
  },
  {
    label: "Desktop",
    value: "900px",
    icon: <DesktopMacRounded />,
  },
];

function WidgetDemoBlock(props: WidgetDemoBlockProps) {
  const theme = useTheme();
  const [responsiveSize, setResponsiveSize] = React.useState(
    _responsiveValues[2]
  );
  const [selectedTab, setSelectedTab] = React.useState(0);

  function renderTabs(selectedTab: number) {
    return (
      <div
        style={{
          position: "relative",
          width: "100%",
          height: "100%",
          marginTop: "-2rem",
        }}
      >
        <div
          style={{
            height: "100%",
            width: "100%",
            display: "flex",
            justifyContent: "center",
            borderRadius: "0.5rem",
            padding: "1rem",
            position: "absolute",
            opacity: selectedTab === 0 ? 1 : 0,
            pointerEvents: selectedTab === 0 ? "all" : "none",
            backgroundColor:
              selectedTab === 0
                ? theme.palette.background.paper
                : "transparent",
          }}
        >
          <motion.div
            animate={{
              maxWidth: responsiveSize.value,
            }}
            style={{
              height: "100%",
              width: "100%",
            }}
          >
            <CustomIframe url={props.demoUrl} />
          </motion.div>
        </div>
        <div
          style={{
            opacity: selectedTab === 0 ? 0 : 1,
            zIndex: selectedTab === 0 ? -1 : 0,
            width: "100%",
            height: "100%",
            position: "absolute",
            marginTop: "-1rem",
          }}
        >
          <CodeBlock url={props.rawCodeUrl} height="70vh" />
        </div>
      </div>
    );
  }

  return (
    <div>
      <Grid
        spacing={2}
        container
        direction="column"
        style={{
          borderRadius: "10px",
        }}
      >
        <Grid item>
          <div
            style={{
              border: "1px solid #cccccc50",
              borderRadius: "0.5rem",
              padding: "1rem",
            }}
          >
            <Grid
              container
              direction="row"
              justifyContent="center"
              alignItems="center"
              style={{
                height: "100%",
              }}
            >
              <Grid item xs={12} md={4}>
                <Typography
                  variant="h6"
                  style={{
                    fontWeight: "bold",
                  }}
                >
                  {props.title}
                </Typography>
              </Grid>
              <Grid
                item
                xs={12}
                md={4}
                style={{
                  display: "flex",
                  justifyContent: "center",
                }}
              >
                {renderResponsiveSelector()}
              </Grid>

              <Grid item xs={12} md={4}>
                <Grid
                  container
                  direction="row"
                  justifyContent="flex-end"
                  alignItems="center"
                >
                  {[0, 1].map((item) => (
                    <Grid item>
                      <Button
                        style={{
                          textTransform: "capitalize",
                          color: `${selectedTab == item ? "white" : ""}`,
                          backgroundColor: `${
                            selectedTab == item
                              ? `${theme.palette.secondary.main}`
                              : ""
                          }`,
                        }}
                        onClick={() => {
                          setSelectedTab(item);
                        }}
                      >
                        {item === 0 ? "Demo" : "Code"}
                      </Button>
                    </Grid>
                  ))}
                  <Grid item>
                    <a
                      href={props.codeUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <IconButton>
                        <GitHub />
                      </IconButton>
                    </a>
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
          </div>
        </Grid>

        <Grid item>
          <div
            style={{
              display: "flex",
              flexDirection: "row",
              justifyContent: "center",
              height: "70vh",
            }}
          >
            {renderTabs(selectedTab)}
          </div>
        </Grid>
      </Grid>
    </div>
  );

  function renderResponsiveSelector() {
    return (
      <motion.div
        animate={{
          scale: selectedTab == 0 ? 1 : 0,
        }}
      >
        <>
          {_responsiveValues.map((item) => (
            <IconButton
              area-label={item.label}
              size="small"
              style={{
                color: `${
                  item.value === responsiveSize.value
                    ? "white"
                    : theme.palette.secondary.main
                }`,
                backgroundColor: `${
                  item.value === responsiveSize.value
                    ? theme.palette.secondary.main
                    : `${theme.palette.secondary.main}10`
                }`,
                padding: "6px",
                borderRadius: "4px",
                marginRight: "0.5rem",
              }}
              onClick={() => {
                setResponsiveSize(item);
              }}
            >
              {item.icon}
            </IconButton>
          ))}
        </>
      </motion.div>
    );
  }
}

export default WidgetDemoBlock;
