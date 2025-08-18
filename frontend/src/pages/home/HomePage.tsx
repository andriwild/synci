import {Flex} from 'antd';
import './HomePage.css';
import {AvailableSportsComponent} from "./components/AvailableSportsComponent.tsx";
import {TutorialStepperComponent} from "./components/TutorialStepperComponent.tsx";
import {FirstImpressionComponent} from "./components/FirstImpressionComponent.tsx";

export const HomePage = () => {
    return (
        <Flex vertical style={{width: '100%'}} id={"home-container"}>
            <FirstImpressionComponent/>
            <AvailableSportsComponent/>
            <TutorialStepperComponent/>
        </Flex>
    );
};
