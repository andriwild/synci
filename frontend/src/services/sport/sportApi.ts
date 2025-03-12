import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {Sport} from "./entities/sport.ts";
import {PagedRequest, PagedResult} from "../common/PagedResult.ts";
import {SportEvent} from "../event/entities/event.ts";
import {Team} from "../team/entities/team.ts";


export const sportApi = createApi({
    reducerPath: "sportApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/sports"
    }),
    endpoints: build => ({
        getAll: build.query<Sport[], void>({
            query: () => ({
                url: "",
                method: "GET"
            })
        }),
        getById: build.query<Sport, number>({
            query: (id) => ({
                url: `${id}`,
                method: "GET"
            })
        }),
        getEvents: build.query<PagedResult<SportEvent>, PagedRequest>({
            query: (request) => ({
                url: `${request.id}/events?page=${request.page}&pageSize=${request.pageSize}`,
                method: "GET"
            })
        }),
        getTeams: build.query<Team[], string>({
            query: (sportId) => ({
                url: `${sportId}/teams`,
                method: "GET"
            })
        }),
        update: build.mutation<Sport, Sport>({
            query: (sport) => ({
                url: `/${sport.id}`,
                method: "PUT",
                body: sport
            })
        }),
})
})