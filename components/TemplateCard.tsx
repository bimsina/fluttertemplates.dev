import {
  Card,
  CardActionArea,
  CardContent,
  CardMedia,
  Chip,
  Grid,
  Typography,
} from "@material-ui/core";
import Link from "next/link";
import React from "react";
import TemplateCardProps from "@/models/template_card";

export default function TemplateCard(props: TemplateCardProps) {
  return (
    <Grid item md={3} xs={12} sm={6}>
      <Link href={`/templates/${props.id}`} passHref>
        <a>
          <Card
            elevation={0}
            style={{
              margin: "16px",
            }}
          >
            <CardActionArea>
              <CardMedia
                image={props.frontmatter.image}
                title={props.frontmatter.title.toString()}
                style={{
                  height: "10rem",
                }}
              />

              <Typography
                gutterBottom
                variant="h6"
                style={{
                  fontSize: "1rem",
                  margin: "8px",
                }}
              >
                {props.frontmatter.title}
              </Typography>

              <div
                className="categories-list"
                style={{
                  marginLeft: "8px",
                }}
              >
                {props.frontmatter.categories.map((category) => (
                  <Chip
                    label={category}
                    // component="a"
                    // color={props.selected === val ? "primary" : "default"}
                    // variant="default"
                    // clickable
                    style={{
                      marginRight: "4px",
                    }}
                    // key={val}
                    // onClick={() => {
                    //   props.onChange(val);
                    // }}
                  />
                ))}
              </div>
            </CardActionArea>
          </Card>
        </a>
      </Link>
    </Grid>
  );
}
