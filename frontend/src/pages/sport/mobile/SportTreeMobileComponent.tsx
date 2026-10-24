import {useMemo, useState} from "react";
import "./SportTreeMobileComponent.css";
import {Sport} from "../../../services/sport/entities/sport.ts";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {Button, Flex, theme} from "antd";
import {ArrowRight, CaretDown, CaretRight, Compass, UsersThree} from "@phosphor-icons/react";
import {SportDetailComponent} from "../shared-components/SportDetailComponent.tsx";
import {ErrorState, LoadingState} from "../shared-components/TreeStates.tsx";
import {useUser} from "../../../services/user/UserSlice.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {activeOrganisations, DISCOVER_NODE, isTopEvents, sportNode, TreeNode, withLiveOrganisation} from "../shared-components/treeNodes.ts";
import {DiscoverOrganisationsPanel} from "../../organisation/components/DiscoverOrganisationsPanel.tsx";
import {track} from "../../../utils/analytics.ts";

const columnColors = ["#3D5A80", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];

export const SportTreeMobileComponent = () => {
    const user = useUser();
    const {data, isLoading, isError, error} = sportApi.useGetAllQuery();
    const myOrganisations = organisationApi.useGetMineQuery(undefined, {skip: !user});
    const [expandedIds, setExpandedIds] = useState<string[]>([]);
    const [selected, setSelected] = useState<TreeNode | null>(null);
    /** labels of the ancestors of the selected node, shown as breadcrumb in the detail view */
    const [selectedPath, setSelectedPath] = useState<string[]>([]);
    const token = theme.useToken().token;

    const organisations = useMemo(() => activeOrganisations(myOrganisations.data), [myOrganisations.data]);
    const liveSelected = selected ? withLiveOrganisation(selected, organisations) : null;

    const toggleExpand = (id: string) => {
        setExpandedIds((prev) => prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]);
    };

    /** One accordion row; `onOpen` selects the node, `onToggle` expands its children. */
    const renderRow = (
        key: string,
        label: string,
        level: number,
        options: { onOpen: () => void; onToggle?: () => void; expanded?: boolean; icon?: React.ReactNode; italic?: boolean }
    ) => {
        const expandable = !!options.onToggle;
        const foreground = level === 0 ? "white" : "black";
        return (
            <Flex
                key={key}
                justify={"space-between"}
                align={"center"}
                className="tree-item"
                onClick={() => options.onToggle ? options.onToggle() : options.onOpen()}
                style={{
                    display: "flex",
                    width: "100%",
                    padding: "15px",
                    borderBottom: "1px solid darkgrey",
                    justifyContent: "space-between",
                    cursor: "pointer",
                    gap: 10,
                    backgroundColor: columnColors[level % columnColors.length],
                }}
            >
                <Flex align={"center"} gap={10} style={{minWidth: 0}}>
                    {expandable ? (
                        <Button
                            type={"text"}
                            size={"small"}
                            style={{padding: 0, height: "auto"}}
                            icon={options.expanded
                                ? <CaretDown size={16} color={foreground}/>
                                : <CaretRight size={16} color={foreground}/>}
                            onClick={(e) => {
                                e.stopPropagation();
                                options.onToggle?.();
                            }}
                        />
                    ) : (
                        <span style={{display: "inline-block", width: 16}}/>
                    )}
                    {options.icon}
                    <span style={{color: level === 0 ? "white" : undefined, fontStyle: options.italic ? "italic" : undefined}}>{label}</span>
                </Flex>
                <Button
                    shape={"circle"}
                    style={{background: token.colorBgContainer, flexShrink: 0}}
                    icon={<ArrowRight size={16} color={token.colorPrimary}/>}
                    onClick={(e) => {
                        e.stopPropagation();
                        options.onOpen();
                    }}
                />
            </Flex>
        );
    };

    /** Sports and organisation subtrees share the same rendering; the organisation is carried along for the detail view. */
    const renderTree = (sports: Sport[], level = 0, organisation?: MyOrganisation, ancestors: string[] = []): React.ReactNode[] => {
        return sports.map((sport) => {
            const hasSub = sport.subSports.length > 0;
            const isExpanded = expandedIds.includes(sport.id);
            return (
                <div key={sport.id}>
                    {renderRow(sport.id, sport.label, level, {
                        onOpen: () => {
                            if (!organisation) track("sport-select", {sport: sport.label, level});
                            setSelectedPath(ancestors);
                            setSelected(sportNode(sport, organisation));
                        },
                        onToggle: hasSub ? () => toggleExpand(sport.id) : undefined,
                        expanded: isExpanded,
                        icon: organisation && level === 0 ? <UsersThree size={16} color={"white"}/> : undefined,
                    })}
                    {isExpanded && hasSub && renderTree(sport.subSports, level + 1, organisation, [...ancestors, sport.label])}
                </div>
            );
        });
    };

    if (isLoading) {
        return <LoadingState/>;
    }

    if (isError) {
        return <ErrorState error={error}/>;
    }

    const renderSelected = (node: TreeNode) => {
        if (node.kind === "sport") {
            return <SportDetailComponent onBack={() => setSelected(null)} id={node.id} title={node.label}
                                         breadcrumb={selectedPath} organisation={node.organisation} topEvents={isTopEvents(node)} key={node.id}/>;
        }
        return <DiscoverOrganisationsPanel onBack={() => setSelected(null)}/>;
    };

    return (
        <div style={{width: "100%", minWidth: 0}}>
            {liveSelected ? renderSelected(liveSelected)
                : (
                    <Flex vertical className="tree-accordion">
                        {organisations.map((organisation) => renderTree([organisation.sport], 0, organisation))}
                        {user && renderRow(DISCOVER_NODE.id, DISCOVER_NODE.label, 0, {
                            onOpen: () => setSelected(DISCOVER_NODE),
                            icon: <Compass size={16} color={"white"}/>,
                            italic: true,
                        })}
                        {data && data.length > 0 ? renderTree(data) : <p>Keine Sportarten gefunden</p>}
                    </Flex>
                )}
        </div>
    );
}
