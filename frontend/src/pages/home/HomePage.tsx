import {Flex} from 'antd';
import './HomePage.css';
import {AppPromoComponent} from "./components/AppPromoComponent.tsx";
import {TutorialStepperComponent} from "./components/TutorialStepperComponent.tsx";
import {FirstImpressionComponent} from "./components/FirstImpressionComponent.tsx";
import {usePageMeta} from "../../utils/usePageMeta.ts";

export const HomePage = () => {
    usePageMeta();
    return (
        <Flex vertical style={{width: '100%'}} id={"home-container"}>
            <FirstImpressionComponent/>
            <AppPromoComponent/>
            <TutorialStepperComponent/>
        </Flex>
    );
};
