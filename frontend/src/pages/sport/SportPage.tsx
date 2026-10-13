import {FC, useState} from "react";
import {SportTreeComponent} from "./desktop/SportTreeComponent.tsx";
import {SyncConfigComponent} from "./desktop/SyncConfigComponent.tsx";
import "./SportPage.css";
import {SportTreeMobileComponent} from "./mobile/SportTreeMobileComponent.tsx";
import {useResponsive} from "../../utils/useResponsive.ts";
import {SyncConfigBar, SyncConfigDrawer} from "./mobile/SyncConfigDrawer.tsx";
import {usePageMeta} from "../../utils/usePageMeta.ts";

/**
 * < md : accordion tree, subscription in a bottom drawer
 * md-lg: column tree, subscription in a bottom drawer
 * >= lg: column tree with the subscription side panel
 */
export const SportPage: FC = () => {
    const {ready, isMobile, isDesktop} = useResponsive();
    const [drawerOpen, setDrawerOpen] = useState(false);
    usePageMeta({
        title: "Sportarten und Ligen als Kalender-Abo",
        description: "Fussball, Eishockey, Ski Alpin, Motorsport und mehr: Wähle Ligen, Teams oder einzelne Events und abonniere sie in deinem Kalender.",
        path: "/sport",
    });

    if (!ready) {
        return <div className="sport-layout"/>;
    }

    return (
        <div className="sport-layout">
            <h1 className="sr-only">Sportarten und Ligen als Kalender-Abo</h1>
            <div className="sport-main">
                <div className="sport-tree-panel">
                    {isMobile ? <SportTreeMobileComponent/> : <SportTreeComponent/>}
                </div>
                {!isDesktop && <SyncConfigBar onOpen={() => setDrawerOpen(true)}/>}
            </div>
            {isDesktop
                ? <aside className="sport-sidebar"><SyncConfigComponent/></aside>
                : <SyncConfigDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)}/>}
        </div>
    );
};
