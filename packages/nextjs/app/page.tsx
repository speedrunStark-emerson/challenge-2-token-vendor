"use client";

import type { NextPage } from "next";
import Image from "next/image";
import { useAccount } from "@starknet-react/core";

const Home: NextPage = () => {
  const connectedAddress = useAccount();
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5 w-[90%] md:w-[75%]">
          <h1 className="text-center mb-6">
            <span className="block text-2xl mb-2">SpeedRunStark</span>
            <span className="block text-4xl font-bold">
              Challenge #2: 🏵 Token Vendor 🤖
            </span>
          </h1>
          <div className="flex flex-col items-center justify-center">
            <Image
              src="/hero2.png"
              width="727"
              height="231"
              alt="challenge banner"
              className="rounded-xl border-4 border-primary"
            />
            <div className="max-w-3xl">
              <p className="text-center text-lg mt-8">
                🤖 Smart contracts are kind of like &quot;always on&quot;
                vending machines that anyone can access. Let&apos;s make a
                decentralized, digital currency. Then, let&apos;s build an
                unstoppable vending machine that will buy and sell the currency.
                We&apos;ll learn about the &quot;approve&quot; pattern for
                ERC20s and how contract to contract interactions work.
              </p>
              <p className="text-center text-lg">
                🌟 The final deliverable is an app that lets users purchase your
                ERC20 token, transfer it, and sell it back to the vendor. Deploy
                your contracts on your public chain of choice and then deploy
                your app to a public webserver. Submit the url on{" "}
                <a
                  href="https://www.speedrunstark.com/"
                  target="_blank"
                  rel="noreferrer"
                  className="underline"
                >
                  SpeedrunStark.com
                </a>{" "}
                !
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
