import {Button, Flex, Image, Modal, Typography} from "antd";
import {useState} from "react";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";


export const DonationModal = ({buttonStyle, buttonText, textColor}: {buttonStyle: "link" | "text" | "default" | "primary" | "dashed" | undefined, buttonText: string, textColor: string}) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const screen = useBreakpoint();

    const showModal = () => {
        setIsModalOpen(true);
    };
    const handleCancel = () => {
        setIsModalOpen(false);
    };


    return (
        <>
            <Button type={buttonStyle}  onClick={showModal} style={{color: textColor}}>
                {buttonText}
            </Button>
            <Modal title="Danke für deine Unterstützung"
                   onCancel={handleCancel}
                   footer={null}
                   open={isModalOpen}>
                <Flex gap={10}  vertical
                      align={"center"}>
                    {screen.md ?
                        <Image
                            src={"./assets/twint/Synci_twint_code.png"}
                            preview={false}
                            width={400}
                        />
                        :
                        <Button
                            onClick={() => {
                                window.open("https://go.twint.ch/1/e/tw?tw=acq.X02uCbRoQrmFpKiqJPEblOh-AIeo9bKVcSjWppoaVe4IFq8CAUymVV_UWtgY8DjH")
                            }
                            }>Twint
                        </Button>
                    }
                    <Typography.Text>Falls du kein Twint hast, kannst du uns hier unterstützen:</Typography.Text>
                    <Typography.Link
                        onClick={() => {
                            window.open("https://buymeacoffee.com/boostershack")
                        }
                        }
                    >https://buymeacoffee.com/boostershack</Typography.Link>
                </Flex>
            </Modal>
        </>
    );
}