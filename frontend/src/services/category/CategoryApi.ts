import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {SportCategory} from "./entities/sportCategory.ts";


export const categoryApi = createApi({
    reducerPath: "sportCategoryApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/sportCategory"
    }),
    endpoints: build => ({
        getAll: build.query<SportCategory[], void>({
            query: () => ({
                url: "/",
                method: "GET"
            })
        })
    })
})