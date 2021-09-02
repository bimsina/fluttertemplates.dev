import React, { useEffect } from "react";
import {
  Backdrop,
  Chip,
  CircularProgress,
  Grid,
  Input,
  MenuItem,
  Select,
  TextField,
} from "@material-ui/core";

import AdminWrapper from "./AdminWrapper";
import { useForm, Controller, SubmitHandler } from "react-hook-form";
import Product from "../../models/Product";
import CustomButton from "../../components/custom_button";
import { fetchCategories } from "../../utils/fetchcategories";
import Category from "../../models/Category";
import firebase from "../../firebase/clientApp";

export default function AdminAddTemplates() {
  const {
    control,
    formState: { errors },
    getValues,
    handleSubmit,
  } = useForm<Product>();

  const onSubmit: SubmitHandler<Product> = (data) => {
    data.categories = selectedCategory;
    addTemplate(data);
  };

  async function addTemplate(data: Product) {
    setLoading(true);
    const _data = await firebase.firestore().collection("templates").add(data);
    setLoading(false);

    if (_data) {
      alert("template added");
    }
  }

  const [categories, setCategories] = React.useState<Category[]>([]);

  const [loading, setLoading] = React.useState(true);

  const [selectedCategory, setSelectedCategory] = React.useState<string[]>([]);

  const handleChange = (event: React.ChangeEvent<{ value: unknown }>) => {
    setSelectedCategory(event.target.value as string[]);
  };

  const handleCategoryChange = (
    event: React.ChangeEvent<{ value: unknown }>
  ) => {
    const { options } = event.target as HTMLSelectElement;
    const value: string[] = [];
    for (let i = 0, l = options.length; i < l; i += 1) {
      if (options[i].selected) {
        value.push(options[i].value);
      }
    }
    setSelectedCategory(value);
  };

  useEffect(() => {
    _fetchCategories();
  }, []);

  async function _fetchCategories() {
    setLoading(true);

    const _categories = await fetchCategories();
    setCategories(_categories);
    setLoading(false);
  }

  return (
    <AdminWrapper>
      <div>
        <form onSubmit={handleSubmit(onSubmit)}>
          <Grid
            container
            direction="column"
            justifyContent="center"
            alignItems="center"
            spacing={2}
            style={{
              height: "80vh",
              width: "100%",
            }}
          >
            <Grid item>
              <Controller
                name="title"
                control={control}
                defaultValue=""
                rules={{ required: true }}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Template Title"
                    variant="filled"
                    required
                    error={errors.title ? true : false}
                    helperText={errors.title ? "Required" : ""}
                  />
                )}
              />
            </Grid>

            <Grid item>
              <Controller
                name="codeGistUrl"
                control={control}
                defaultValue=""
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Code Gist Url"
                    variant="filled"
                  />
                )}
              />
            </Grid>

            <Grid item>
              <Controller
                name="codeUrl"
                control={control}
                defaultValue=""
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Full Source Code Url"
                    variant="filled"
                  />
                )}
              />
            </Grid>

            <Grid item>
              <Controller
                name="demoUrl"
                control={control}
                defaultValue=""
                rules={{ required: true }}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Demo Url"
                    variant="filled"
                    required
                    error={errors.demoUrl ? true : false}
                    helperText={errors.demoUrl ? "Required" : ""}
                  />
                )}
              />
            </Grid>
            <Grid item>
              <Controller
                name="imageUrl"
                control={control}
                defaultValue=""
                rules={{ required: true }}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Image Url"
                    variant="filled"
                    required
                    error={errors.imageUrl ? true : false}
                    helperText={errors.imageUrl ? "Required" : ""}
                  />
                )}
              />
            </Grid>

            <Select
              multiple
              value={selectedCategory}
              onChange={handleChange}
              input={<Input id="select-multiple-chip" />}
              renderValue={(selected) => (
                <div>
                  {(selected as string[]).map((value) => (
                    <Chip
                      key={value}
                      label={
                        categories.filter((val) => val.id == value)[0].title
                      }
                    />
                  ))}
                </div>
              )}
            >
              {categories.map((cat) => (
                <MenuItem key={cat.id} value={cat.id}>
                  {cat.title}
                </MenuItem>
              ))}
            </Select>

            <Grid item>
              <CustomButton
                variant="contained"
                color="primary"
                onClick={handleSubmit(onSubmit)}
              >
                Add Template
              </CustomButton>
            </Grid>
          </Grid>
        </form>
        <Backdrop open={loading}>
          <CircularProgress color="inherit" />
        </Backdrop>
      </div>
    </AdminWrapper>
  );
}
