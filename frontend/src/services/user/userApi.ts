import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";

export const userApi = createApi({
    reducerPath: "userApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/users"
    }),
    endpoints: build => ({
        deleteMe: build.mutation<number, void>({
            query: () => ({
                url: "/me",
                method: "DELETE"
            })
        })
    })
})
