import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers.ts";
import {PagedResult} from "../common/PagedResult.ts";
import {
    EventAnswer,
    EventResponseSummary,
    MyOrganisation,
    Organisation,
    OrganisationMember,
    OrganisationSummary,
    OrgRole
} from "./entities/organisation.ts";
import {GroupRequest, OrganisationEventRequest, OrganisationRequest} from "./entities/organisationDto.ts";
import {Sport} from "../sport/entities/sport.ts";
import {SportEvent} from "../event/entities/event.ts";
import {sportApi} from "../sport/sportApi.ts";

export type DiscoverRequest = {
    searchTerm?: string;
    page: number;
    pageSize: number;
};

/** Organisation events are listed through sportApi.getEvents, so event mutations have to refresh that cache. */
const refreshSportEvents = async (_arg: unknown, {dispatch, queryFulfilled}: {
    dispatch: (action: unknown) => unknown,
    queryFulfilled: Promise<unknown>
}) => {
    try {
        await queryFulfilled;
        dispatch(sportApi.util.invalidateTags(["SportEvents"]));
    } catch {
        // the mutation itself reports the error
    }
};

export const organisationApi = createApi({
    reducerPath: "organisationApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/organisations"
    }),
    tagTypes: ["Organisation", "OrganisationMembers", "OrganisationDiscover", "EventResponses"],
    endpoints: build => ({
        // ---- organisations ----
        getMine: build.query<MyOrganisation[], void>({
            query: () => ({url: "", method: "GET"}),
            providesTags: ["Organisation"]
        }),
        discover: build.query<PagedResult<OrganisationSummary>, DiscoverRequest>({
            query: (request) => {
                const params = new URLSearchParams({
                    page: String(request.page),
                    pageSize: String(request.pageSize),
                });
                if (request.searchTerm) {
                    params.append("searchTerm", request.searchTerm);
                }
                return {url: `/discover?${params.toString()}`, method: "GET"};
            },
            providesTags: ["OrganisationDiscover"]
        }),
        getById: build.query<Organisation, string>({
            query: (id) => ({url: `/${id}`, method: "GET"}),
            providesTags: (_result, _error, id) => [{type: "Organisation", id}]
        }),
        create: build.mutation<Organisation, OrganisationRequest>({
            query: (organisation) => ({url: "", method: "POST", body: organisation}),
            invalidatesTags: ["Organisation", "OrganisationDiscover"]
        }),
        update: build.mutation<Organisation, { id: string } & OrganisationRequest>({
            query: ({id, ...organisation}) => ({url: `/${id}`, method: "PUT", body: organisation}),
            invalidatesTags: ["Organisation", "OrganisationDiscover"]
        }),
        delete: build.mutation<number, string>({
            query: (id) => ({url: `/${id}`, method: "DELETE"}),
            invalidatesTags: ["Organisation", "OrganisationDiscover"],
            onQueryStarted: refreshSportEvents
        }),

        // ---- membership ----
        requestJoin: build.mutation<OrganisationMember, string>({
            query: (id) => ({url: `/${id}/join-requests`, method: "POST"}),
            invalidatesTags: ["Organisation", "OrganisationDiscover"]
        }),
        leave: build.mutation<number, string>({
            query: (id) => ({url: `/${id}/members/me`, method: "DELETE"}),
            invalidatesTags: ["Organisation", "OrganisationMembers", "OrganisationDiscover"]
        }),
        getMembers: build.query<OrganisationMember[], string>({
            query: (id) => ({url: `/${id}/members`, method: "GET"}),
            providesTags: ["OrganisationMembers"]
        }),
        approveMember: build.mutation<OrganisationMember, { organisationId: string; memberId: string }>({
            query: ({organisationId, memberId}) => ({
                url: `/${organisationId}/members/${memberId}/approve`,
                method: "PUT"
            }),
            invalidatesTags: ["OrganisationMembers", "OrganisationDiscover"]
        }),
        updateMemberRole: build.mutation<OrganisationMember, { organisationId: string; memberId: string; role: OrgRole }>({
            query: ({organisationId, memberId, role}) => ({
                url: `/${organisationId}/members/${memberId}/role`,
                method: "PUT",
                body: {role}
            }),
            invalidatesTags: ["OrganisationMembers"]
        }),
        removeMember: build.mutation<number, { organisationId: string; memberId: string }>({
            query: ({organisationId, memberId}) => ({
                url: `/${organisationId}/members/${memberId}`,
                method: "DELETE"
            }),
            invalidatesTags: ["OrganisationMembers", "OrganisationDiscover"]
        }),

        // ---- groups (child nodes in the sport tree) ----
        createGroup: build.mutation<Sport, { organisationId: string } & GroupRequest>({
            query: ({organisationId, ...group}) => ({url: `/${organisationId}/groups`, method: "POST", body: group}),
            invalidatesTags: ["Organisation"]
        }),
        updateGroup: build.mutation<Sport, { organisationId: string; groupId: string } & GroupRequest>({
            query: ({organisationId, groupId, ...group}) => ({
                url: `/${organisationId}/groups/${groupId}`,
                method: "PUT",
                body: group
            }),
            invalidatesTags: ["Organisation"]
        }),
        deleteGroup: build.mutation<number, { organisationId: string; groupId: string }>({
            query: ({organisationId, groupId}) => ({url: `/${organisationId}/groups/${groupId}`, method: "DELETE"}),
            invalidatesTags: ["Organisation"],
            onQueryStarted: refreshSportEvents
        }),

        // ---- events (rows in events_table, read through sportApi.getEvents) ----
        createEvent: build.mutation<SportEvent, { organisationId: string } & OrganisationEventRequest>({
            query: ({organisationId, ...event}) => ({url: `/${organisationId}/events`, method: "POST", body: event}),
            invalidatesTags: ["EventResponses"],
            onQueryStarted: refreshSportEvents
        }),
        updateEvent: build.mutation<SportEvent, { organisationId: string; eventId: string } & OrganisationEventRequest>({
            query: ({organisationId, eventId, ...event}) => ({
                url: `/${organisationId}/events/${eventId}`,
                method: "PUT",
                body: event
            }),
            invalidatesTags: ["EventResponses"],
            onQueryStarted: refreshSportEvents
        }),
        deleteEvent: build.mutation<number, { organisationId: string; eventId: string }>({
            query: ({organisationId, eventId}) => ({url: `/${organisationId}/events/${eventId}`, method: "DELETE"}),
            invalidatesTags: ["EventResponses"],
            onQueryStarted: refreshSportEvents
        }),

        // ---- answers to events that ask for them ----
        getResponses: build.query<EventResponseSummary[], string>({
            query: (id) => ({url: `/${id}/responses`, method: "GET"}),
            providesTags: (_result, _error, id) => [{type: "EventResponses", id}]
        }),
        answer: build.mutation<EventResponseSummary, { organisationId: string; eventId: string; answer: EventAnswer }>({
            query: ({organisationId, eventId, answer}) => ({
                url: `/${organisationId}/events/${eventId}/response`,
                method: "PUT",
                body: {answer}
            }),
            // the answer returns the new counts, so the list is updated without reloading it
            onQueryStarted: async ({organisationId}, {dispatch, queryFulfilled}) => {
                try {
                    const {data: summary} = await queryFulfilled;
                    dispatch(organisationApi.util.updateQueryData("getResponses", organisationId, (draft) => {
                        const index = draft.findIndex((s) => s.eventId === summary.eventId);
                        if (index >= 0) draft[index] = summary; else draft.push(summary);
                    }));
                } catch {
                    // the mutation itself reports the error
                }
            }
        }),
    })
});
