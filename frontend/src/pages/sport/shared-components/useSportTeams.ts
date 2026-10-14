import {useEffect, useState} from "react";
import {sportApi} from "../../../services/sport/sportApi.ts";

const PAGE_SIZE = 12;

/**
 * Teams of a sport with debounced search and a "load more" that grows the page size
 * (same approach as useSportEvents, so a refetch simply replaces the list).
 */
export const useSportTeams = (sportId: string, enabled = true) => {
    const [searchInput, setSearchInput] = useState("");
    const [searchTerm, setSearchTerm] = useState("");
    const [limit, setLimit] = useState(PAGE_SIZE);

    useEffect(() => {
        const timeout = setTimeout(() => setSearchTerm(searchInput.trim()), 300);
        return () => clearTimeout(timeout);
    }, [searchInput]);

    useEffect(() => {
        setLimit(PAGE_SIZE);
    }, [sportId, searchTerm]);

    useEffect(() => {
        setSearchInput("");
    }, [sportId]);

    const query = sportApi.useGetTeamsQuery(
        {id: sportId, page: 0, pageSize: limit, searchTerm: searchTerm || undefined},
        {skip: !sportId || !enabled},
    );
    const teams = Array.from(new Map((query.data?.elements ?? []).map((t) => [t.id, t])).values());
    const amount = query.data?.amount ?? 0;

    return {
        teams,
        amount,
        isLoading: query.isLoading,
        isFetching: query.isFetching,
        searchInput,
        setSearchInput,
        searchTerm,
        hasMore: amount > teams.length,
        loadMore: () => setLimit(limit + PAGE_SIZE),
    };
};

export type SportTeams = ReturnType<typeof useSportTeams>;
