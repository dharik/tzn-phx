// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

import "phoenix_html";
import ClassicEditor from "@ckeditor/ckeditor5-build-classic";

import { h, render } from "preact";
import MatchingApp from "./matching";
import AdminMentorList from "./admin/mentors";

import MentorAnswerInput from "./mentor/answer_input";
import ParentAnswerInput from "./parent/answer_input";

import React from "react"
import ReactDOM from "react-dom"

export default class ReactPhoenix {
  static init() {
    const elements = document.querySelectorAll('[data-react-class]')
    Array.prototype.forEach.call(elements, e => {
      const targetId = document.getElementById(e.dataset.reactTargetId)
      const targetDiv = targetId ? targetId : e
      const reactProps = e.dataset.reactProps ? e.dataset.reactProps : "{}"
      const reactClass = Array.prototype.reduce.call(e.dataset.reactClass.split('.'), (acc, el) => { return acc[el] }, window);
      const reactElement = React.createElement(reactClass, JSON.parse(reactProps))
      ReactDOM.render(reactElement, targetDiv)
    })
  }
}

document.addEventListener("DOMContentLoaded", e => {
  ReactPhoenix.init()
})

window.Components = {
  MentorAnswerInput,
  ParentAnswerInput
}

if (document.getElementById("matching-app")) {
  render(<MatchingApp />, document.getElementById("matching-app"));
}

if (document.getElementById("admin-mentors")) {
  render(<AdminMentorList />, document.getElementById("admin-mentors"));
}

for (const element of document.getElementsByClassName("rte")) {
  ClassicEditor.create(element)
    .then((editor) => {
      // console.log( "created editor", editor );
    })
    .catch((error) => {
      // console.error( error );
    });
}

for (const el of document.getElementsByClassName("rtem")) {
  ClassicEditor.create(el, {
    toolbar: ["bold", "italic", "bulletedlist", "numberedlist"],
  })
    .then((editor) => {
      // console.log( "created editor", editor );
    })
    .catch((error) => {
      // console.error( error );
    });
}
