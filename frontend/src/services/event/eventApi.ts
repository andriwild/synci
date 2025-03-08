import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";


export const eventApi = createApi({
    reducerPath: "eventApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/events"
    }),
    endpoints: build => ({
        getSportBasicData: build.query<Event[], string>({
            query: id => ({
                url: `/${id}`,
                method: "GET"
            }),
        }),
        getEventList: build.query<Event[], void>({
            query: () => ({
                url: "/",
                method: "GET"
            }),
        }),
    })
})