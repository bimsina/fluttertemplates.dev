import {
  Button,
  Divider,
  Grid,
  IconButton,
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

interface ComponentDemoBlockProps {
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

function ComponentDemoBlock(props: ComponentDemoBlockProps) {
  const theme = useTheme();
  const [responsiveSize, setResponsiveSize] = React.useState(
    _responsiveValues[2]
  );
  const [selectedTab, setSelectedTab] = React.useState(0);

  function renderTabs(selectedTab: number) {
    if (selectedTab == 0) {
      return (
        <div
          style={{
            height: "100%",
            width: "100%",
            display: "flex",
            justifyContent: "center",
            borderRadius: "0.5rem",
            padding: "1rem",
            backgroundColor: theme.palette.background.paper,
          }}
        >
          <iframe
            src={props.demoUrl}
            style={{
              backgroundColor: theme.palette.background.paper,
              maxWidth: responsiveSize.value,
              height: "100%",
              width: "100%",
              border: "none",
            }}
          ></iframe>
        </div>
      );
    } else {
      return (
        <div
          style={{
            width: "100%",
          }}
        >
          <CodeBlock url={props.rawCodeUrl} height="70vh" />
        </div>
      );
    }
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
              height: "80px",
              border: "1px solid #cccccc50",
              borderRadius: "0.5rem",
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
              <Grid item>
                <Typography
                  variant="h6"
                  style={{
                    fontWeight: "bold",
                    marginLeft: "1rem",
                  }}
                >
                  {props.title}
                </Typography>
              </Grid>

              <Grid
                item
                style={{
                  display: "flex",
                  flexGrow: 1,
                  flexDirection: "row",
                  justifyContent: "center",
                }}
              >
                {selectedTab == 0 ? (
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
                ) : (
                  <div> </div>
                )}
              </Grid>
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

              <Grid item>
                <a
                  href={props.demoUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <IconButton>
                    <OpenInNewRounded />
                  </IconButton>
                </a>
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
}

export default ComponentDemoBlock;
