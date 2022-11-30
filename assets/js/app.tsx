import 'phoenix_html';
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';

import ClassicEditor from '@ckeditor/ckeditor5-build-classic';

import ParentAnswerInput from './parent/answer_input';
import AdminAnswerInput from './admin/answer_input';

import React from 'react';
import ReactDOM from 'react-dom';
import { createRoot } from 'react-dom/client';
export default class ReactPhoenix {
  static init() {
    const elements = document.querySelectorAll('[data-react-class]');
    Array.prototype.forEach.call(elements, (e) => {
      const targetId = document.getElementById(e.dataset.reactTargetId);
      const targetDiv = targetId ? targetId : e;
      const reactProps = e.dataset.reactProps ? e.dataset.reactProps : '{}';
      const reactClass = Array.prototype.reduce.call(
        e.dataset.reactClass.split('.'),
        (acc, el) => {
          return acc[el];
        },
        window
      );
      const reactElement = React.createElement(reactClass, JSON.parse(reactProps));
      const root = createRoot(targetDiv);
      root.render(reactElement);
    });
  }
}

document.addEventListener('DOMContentLoaded', (e) => {
  ReactPhoenix.init();
});

window.Components = {
  ParentAnswerInput,
  AdminAnswerInput,
};

for (const element of document.getElementsByClassName('rte')) {
  ClassicEditor.create(element)
    .then((editor) => {
      // console.log( "created editor", editor );
    })
    .catch((error) => {
      // console.error( error );
    });
}

for (const el of document.getElementsByClassName('rtem')) {
  ClassicEditor.create(el, {
    toolbar: ['bold', 'italic', 'bulletedlist', 'numberedlist', 'link'],
  })
    .then((editor) => {
      // console.log( "created editor", editor );
    })
    .catch((error) => {
      // console.error( error );
    });
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, { params: { _csrf_token: csrfToken } });
liveSocket.connect();

// Expose liveSocket on window for web console debug logs and latency simulation:
//  liveSocket.enableDebug()
//  liveSocket.enableLatencySim(200)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket
