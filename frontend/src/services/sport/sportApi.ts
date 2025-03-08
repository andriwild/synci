import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {Sport} from "./entities/sport.ts";


export const sportApi = createApi({
    reducerPath: "sportApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/sports"
    }),
    endpoints: build => ({
        getAll: build.query<Sport[], void>({
            query: () => ({
                url: "/",
                method: "GET"
            })
        }),
        getById: build.query<Sport, number>({
            query: (id) => ({
                url: `/${id}`,
                method: "GET"
            })
        }),
        create: build.mutation<Sport, Sport>({
            query: (sport) => ({
                url: "/",
                method: "POST",
                body: sport
            })
        }),
    })
})