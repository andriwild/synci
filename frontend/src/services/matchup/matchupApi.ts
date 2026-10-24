import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {PagedResult} from "../common/PagedResult.ts";
import {SportEvent} from "../event/entities/event.ts";

export type MatchupEventsRequest = {
    sourceId: number;
    teamA: string;
    teamB: string;
    page: number;
    pageSize: number;
};

/** Upcoming games between two teams, to preview a Top Event before it is added. */
export const matchupApi = createApi({
    reducerPath: "matchupApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/matchups"
    }),
    endpoints: build => ({
        getEvents: build.query<PagedResult<SportEvent>, MatchupEventsRequest>({
            query: (request) => ({
                url: `/events?${new URLSearchParams({
                    sourceId: String(request.sourceId),
                    teamA: request.teamA,
                    teamB: request.teamB,
                    page: String(request.page),
                    pageSize: String(request.pageSize),
                }).toString()}`,
                method: "GET"
            })
        }),
    })
});
