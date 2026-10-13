import {Flex} from 'antd';
import './HomePage.css';
import {AvailableSportsComponent} from "./components/AvailableSportsComponent.tsx";
import {TutorialStepperComponent} from "./components/TutorialStepperComponent.tsx";
import {FirstImpressionComponent} from "./components/FirstImpressionComponent.tsx";
import {usePageMeta} from "../../utils/usePageMeta.ts";

export const HomePage = () => {
    usePageMeta({
        title: "Sport-Termine automatisch in deinem Kalender",
        description: "Abonniere Ligen, Teams und Events wie Super League, Eishockey oder Skirennen als Kalender-Abo. Alle Spiele automatisch in Google Kalender, Outlook und Apple Kalender.",
        path: "/",
    });
    return (
        <Flex vertical style={{width: '100%'}} id={"home-container"}>
            <FirstImpressionComponent/>
            <AvailableSportsComponent/>
            <TutorialStepperComponent/>
        </Flex>
    );
};
